package tech.cherri.linepayexample;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import tech.cherri.tpdirect.api.TPDLinePay;
import tech.cherri.tpdirect.api.TPDLinePayResult;
import tech.cherri.tpdirect.api.TPDSetup;
import tech.cherri.tpdirect.callback.TPDGetPrimeFailureCallback;
import tech.cherri.tpdirect.callback.TPDLinePayGetPrimeSuccessCallback;
import tech.cherri.tpdirect.callback.TPDLinePayResultListener;
import tech.cherri.tpdirect.exception.TPDLinePayException;

public class MainActivity extends AppCompatActivity implements TPDGetPrimeFailureCallback, TPDLinePayGetPrimeSuccessCallback, View.OnClickListener, TPDLinePayResultListener {
    private static final String TAG = "MainActivity";
    private static final int REQUEST_READ_PHONE_STATE = 101;
    private RelativeLayout linePayBTN;
    private TPDLinePay tpdLinePay;
    private TextView getPrimeResultStateTV;
    private TextView linePayResultTV;
    private TextView totalAmountTV;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        setupViews();

        Log.d(TAG, "SDK version is " + TPDSetup.getVersion());

        //Setup environment.
        TPDSetup.initInstance(getApplicationContext(),
                Constants.APP_ID, Constants.APP_KEY, Constants.SERVER_TYPE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions();
        } else {
            prepareLinePay();
        }

        handleIncomingIntent(getIntent());
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private void requestPermissions() {
        if (ContextCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
            Log.d(TAG, "PERMISSION IS ALREADY GRANTED");
            prepareLinePay();
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_PHONE_STATE}, REQUEST_READ_PHONE_STATE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case REQUEST_READ_PHONE_STATE:
                if ((grantResults.length > 0) && (grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    Log.d(TAG, "PERMISSION_GRANTED");
                }
                prepareLinePay();
                break;
            default:
                break;
        }
    }

    private void prepareLinePay() {
        boolean isLinePayAvailable = TPDLinePay.isLinePayAvailable(this.getApplicationContext());
        Toast.makeText(this, "isLinePayAvailable : "
                + isLinePayAvailable, Toast.LENGTH_SHORT).show();
        try {
            if (isLinePayAvailable) {
                tpdLinePay = new TPDLinePay(getApplicationContext(), Constants.TAPPAY_LINEPAY_RESULT_CALLBACK_URI);
                linePayBTN.setEnabled(true);
            } else {
                throw new TPDLinePayException("LinePay is not available");
            }
        } catch (TPDLinePayException e) {
            showMessage(e.getMessage());
            linePayBTN.setEnabled(false);
        }
    }

    private void setupViews() {
        totalAmountTV = (TextView) findViewById(R.id.totalAmountTV);
        totalAmountTV.setText("Total amount : 1.00 元");
        getPrimeResultStateTV = (TextView) findViewById(R.id.getPrimeResultStateTV);
        linePayResultTV = (TextView) findViewById(R.id.linePayResultTV);
        linePayBTN = (RelativeLayout) findViewById(R.id.linePayBTN);
        linePayBTN.setOnClickListener(this);
    }


    @Override
    public void onClick(View view) {
        showProgressDialog();
        tpdLinePay.getPrime(this, this);
    }


    @Override
    public void onSuccess(String prime) {
        hideProgressDialog();
        String resultStr = "Your prime is " + prime
                + "\n\nUse below cURL to get payment url with Pay-by-Prime API on your server side: \n"
                + ApiUtil.generatePayByPrimeCURLForSandBox(prime,
                Constants.PARTNER_KEY,
                Constants.MERCHANT_ID);

        showMessage(resultStr);
        Log.d(TAG, resultStr);

        //Proceed LINE Pay with below function.
//        tpdLinePay.redirectWithUrl("Your payment url ");

    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIncomingIntent(intent);
    }

    private void handleIncomingIntent(Intent intent) {
        if (intent.getDataString() != null && intent.getDataString().contains(Constants.TAPPAY_LINEPAY_RESULT_CALLBACK_URI)) {
            if (tpdLinePay == null) {
                prepareLinePay();
            }

            showProgressDialog();
            tpdLinePay.parseToLinePayResult(getApplicationContext(), intent.getData(), this);
        }
    }

    @Override
    public void onFailure(int status, String msg) {
        hideProgressDialog();
        showMessage("GetPrime failed , status = " + status + ", msg : " + msg);
    }

    private void showMessage(String s) {
        getPrimeResultStateTV.setText(s);
    }


    public ProgressDialog mProgressDialog;

    protected void showProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(this);
            mProgressDialog.setIndeterminate(true);
            mProgressDialog.setMessage("Loading...");
        }

        mProgressDialog.show();
    }

    protected void hideProgressDialog() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }

    @Override
    public void onParseSuccess(TPDLinePayResult tpdLinePayResult) {
        hideProgressDialog();
        if (tpdLinePayResult != null) {
            linePayResultTV.setText("status:" + tpdLinePayResult.getStatus()
                    + "\nrec_trade_id:" + tpdLinePayResult.getRecTradeId()
                    + "\nbank_transaction_id:" + tpdLinePayResult.getBankTransactionId()
                    + "\norder_number:" + tpdLinePayResult.getOrderNumber());
        }
    }

    @Override
    public void onParseFail(int status, String msg) {
        hideProgressDialog();
        linePayResultTV.setText("Parse LINE Pay result failed  status : " + status + " , msg : " + msg);
    }
}
