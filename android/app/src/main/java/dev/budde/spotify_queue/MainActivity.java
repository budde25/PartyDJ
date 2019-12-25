package dev.budde.spotify_queue;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import com.spotify.protocol.client.Subscription;
import com.spotify.protocol.types.PlayerState;
import com.spotify.protocol.types.Repeat;
import com.spotify.protocol.types.Track;
import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;


public class MainActivity extends FlutterActivity {

    private static final String CLIENT_ID = "12e51e7fd567478db5db871585124355";
    private static final String REDIRECT_URI = "dev.budde.spotifyqueue://callback";
    private SpotifyAppRemote mSpotifyAppRemote;
    private String userToken;
    private String username;

    private static final int REQUEST_CODE = 1337;
    private static final String CHANNEL = "dev.budde.spotify_queue";
    private static MethodChannel methodChannel;

    Handler handler = new Handler();
    Track currentTrack;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        login();
        methodChannel = new MethodChannel(getFlutterView(), CHANNEL);
        methodChannel.setMethodCallHandler(
                (call, result) -> {
                    // Note: this method is invoked on the main thread.
                    switch (call.method) {
                        case ("play"):
                            play(call.argument("track"));
                            break;
                        case ("token"):
                            result.success(userToken);
                            break;
                        case ("user"):
                            result.success(username);
                            break;
                    }
                });

    }

    @Override
    protected void onStart() {
        super.onStart();
        ConnectionParams connectionParams =
                new ConnectionParams.Builder(CLIENT_ID)
                        .setRedirectUri(REDIRECT_URI)
                        .showAuthView(true)
                        .build();


        SpotifyAppRemote.connect(this, connectionParams,
                new Connector.ConnectionListener() {

                    @Override
                    public void onConnected(SpotifyAppRemote spotifyAppRemote) {
                        mSpotifyAppRemote = spotifyAppRemote;
                        Log.d("MainActivity", "Connected! Yay!");

                        // Now you can start interacting with App Remote
                        connected();
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        Log.e("MainActivity", throwable.getMessage(), throwable);
                        //login();
                        // Something went wrong when attempting to connect! Handle errors here
                    }
                });
    }

    private void play(String track) {
        mSpotifyAppRemote.getPlayerApi().play(track);
    }

    private void repeat(int state){
        mSpotifyAppRemote.getPlayerApi().setRepeat(state);
    }

    private void login(){
        AuthenticationRequest.Builder builder =
                new AuthenticationRequest.Builder(CLIENT_ID, AuthenticationResponse.Type.TOKEN, REDIRECT_URI);

        builder.setScopes(new String[]{"streaming","user-library-modify"});
        AuthenticationRequest request = builder.build();

        AuthenticationClient.openLoginActivity(this, REQUEST_CODE, request);
    }

    @Override
    protected void onStop() {
        super.onStop();
        SpotifyAppRemote.disconnect(mSpotifyAppRemote);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        // Check if result comes from the correct activity
        if (requestCode == REQUEST_CODE) {
            AuthenticationResponse response = AuthenticationClient.getResponse(resultCode, intent);
            userToken = response.getAccessToken();
            switch (response.getType()) {
                // Response was successful and contains auth token
                case TOKEN:
                    // Handle successful response
                    break;

                // Auth flow returned an error
                case ERROR:
                    // Handle error response
                    break;

                // Most likely auth flow was cancelled
                default:
                    // Handle other cases
            }
        }
    }

    private void connected(){
        mSpotifyAppRemote.getPlayerApi()
                .subscribeToPlayerState()
                .setEventCallback(playerState -> {
                    currentTrack = playerState.track;
                    long position = playerState.playbackPosition;
                    long duration = playerState.track.duration;
                    long timeLeft = duration - position;
                    boolean isPaused = playerState.isPaused;

                    waitToEnd(currentTrack, timeLeft, isPaused);
                });
    }

    private void waitToEnd(Track track, long timeLeft, boolean isPaused) {
        handler.removeCallbacksAndMessages(null);
        if (!isPaused) {
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (track.equals(currentTrack)) {
                        Log.d("playerState", "Track Ended");
                        methodChannel.invokeMethod("trackEnd", "true");
                    }
                }
            }, timeLeft - 1000);
        }

    }





}

