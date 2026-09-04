const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

// RevenueCat secret key — never in source, set via:
//   firebase functions:secrets:set REVENUECAT_SECRET_KEY
const revenueCatSecretKey = defineSecret("REVENUECAT_SECRET_KEY");

const REVENUECAT_PROJECT_ID = "proj37d65fb6";
const HINT_CURRENCY_CODE = "HINT";

/// Spends hint tokens for a player.
///
/// RevenueCat's client SDK can read a virtual currency balance directly, but
/// refuses to let a client spend/decrement one — that has to come from a
/// backend holding the secret key, so a modified client can never grant
/// itself free tokens. This is that backend: the Flutter app calls this
/// with its own RevenueCat app user id and how many tokens one hint costs,
/// and this function is the only thing that ever talks to RevenueCat's
/// virtual-currency transaction endpoint.
///
/// POST body: { "appUserId": "<revenuecat app user id>", "amount": 1 }
/// Success:   200 { "ok": true }
/// Failure:   4xx/5xx { "error": "<code>" } — including 422 when the
///            customer's balance is too low, which RevenueCat itself
///            enforces (this function never trusts a client-reported
///            balance).
exports.spendHintTokens = onRequest(
  { secrets: [revenueCatSecretKey] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "method_not_allowed" });
      return;
    }

    const { appUserId, amount } = req.body ?? {};
    if (typeof appUserId !== "string" || appUserId.trim() === "") {
      res.status(400).json({ error: "missing_app_user_id" });
      return;
    }
    if (typeof amount !== "number" || !Number.isInteger(amount) || amount <= 0) {
      res.status(400).json({ error: "invalid_amount" });
      return;
    }

    const url =
      `https://api.revenuecat.com/v2/projects/${REVENUECAT_PROJECT_ID}` +
      `/customers/${encodeURIComponent(appUserId)}/virtual_currencies/transactions`;

    let rcResponse;
    try {
      rcResponse = await fetch(url, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${revenueCatSecretKey.value()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          adjustments: { [HINT_CURRENCY_CODE]: -amount },
        }),
      });
    } catch (e) {
      res.status(502).json({ error: "revenuecat_unreachable" });
      return;
    }

    if (!rcResponse.ok) {
      // 422 here specifically means "not enough tokens" — RevenueCat's own
      // balance check, not this function's, which is the point: the real
      // balance lives with RevenueCat, never trusted from the client.
      const detail = await rcResponse.text().catch(() => "");
      res.status(rcResponse.status).json({
        error: rcResponse.status === 422 ? "insufficient_balance" : "revenuecat_error",
        detail,
      });
      return;
    }

    res.status(200).json({ ok: true });
  },
);
