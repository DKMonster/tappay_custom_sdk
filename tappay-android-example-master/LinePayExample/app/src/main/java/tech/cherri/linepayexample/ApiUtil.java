package tech.cherri.linepayexample;

import org.json.JSONException;
import org.json.JSONObject;


public class ApiUtil {
    public static String generatePayByPrimeCURLForSandBox(String prime, String partnerKey, String merchantId) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("curl -X POST ");
        stringBuilder.append(Constants.TAPPAY_DOMAIN_SANDBOX + Constants.TAPPAY_PAY_BY_PRIME_URL);
        stringBuilder.append(" -H 'content-type: application/json' ");
        stringBuilder.append(" -H 'x-api-key: " + partnerKey + "' ");
        stringBuilder.append(" -d '");

        JSONObject bodyJO = new JSONObject();
        try {
            bodyJO.put("partner_key", partnerKey);
            bodyJO.put("prime", prime);
            bodyJO.put("merchant_id", merchantId);
            bodyJO.put("amount", 1);
            bodyJO.put("currency", "TWD");
            bodyJO.put("order_number", "SN0001");
            bodyJO.put("details", "item descriptions");
            JSONObject cardHolderJO = new JSONObject();
            cardHolderJO.put("phone_number", "+886912345678");
            cardHolderJO.put("name", "Cardholder");
            cardHolderJO.put("email", "Cardholder@email.com");

            bodyJO.put("cardholder", cardHolderJO);

            JSONObject resultUrlJO = new JSONObject();
            resultUrlJO.put("frontend_redirect_url", Constants.FRONTEND_REDIRECT_URL_EXAMPLE);
            resultUrlJO.put("backend_notify_url", Constants.BACKEND_NOTIFY_URL_EXAMPLE);

            bodyJO.put("result_url", resultUrlJO);

        } catch (JSONException e) {
            e.printStackTrace();
        }

        stringBuilder.append(bodyJO.toString());
        stringBuilder.append("'");
        return stringBuilder.toString();
    }

}
