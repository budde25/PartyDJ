package dev.budde.spotify_queue;

import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import com.spotify.protocol.types.Track;

import java.util.Arrays;
import java.util.List;


public class MainActivity extends FlutterActivity{

    private static final String CLIENT_ID = "12e51e7fd567478db5db871585124355";
    private static final String REDIRECT_URI = "dev.budde.spotifyqueue://callback";
    private SpotifyAppRemote mSpotifyAppRemote;

    private static final String CHANNEL = "dev.budde.spotify_queue";
    private static MethodChannel methodChannel;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        //login();
        methodChannel = new MethodChannel(getFlutterView(), CHANNEL);
        methodChannel.setMethodCallHandler(
                (call, result) -> {
                    // Note: this method is invoked on the main thread.
                    switch (call.method) {
                        case ("play_song"):
                            playSong(call.argument("track"));
                            break;
                        case ("play"):
                            play();
                            break;
                        case ("pause"):
                            pause();
                            break;
                        case ("skip_next"):
                            skipNext();
                            break;
                        case ("skip_previous"):
                            skipPrevious();
                            break;
                        case ("connect"):
                            if (mSpotifyAppRemote == null || !mSpotifyAppRemote.isConnected()) {
                                Log.d("d","a");
                                connectSpotify();
                            }
                            break;
                        default:
                            Log.e("Error", "invalid method: " + call.method);
                    }
                });

    }

    private void connectSpotify() {
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


                        // Something went wrong when attempting to connect! Handle errors here
                    }
                });
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    private void playSong(String track) {
        mSpotifyAppRemote.getPlayerApi().play(track);
    }

    private void play() {
        mSpotifyAppRemote.getPlayerApi().resume();
    }
    private void pause(){
        mSpotifyAppRemote.getPlayerApi().pause();
    }

    private void skipNext() {
        mSpotifyAppRemote.getPlayerApi().skipNext();
    }

    private void skipPrevious() {
        mSpotifyAppRemote.getPlayerApi().skipPrevious();
    }

    @Override
    protected void onStop() {
        super.onStop();
        SpotifyAppRemote.disconnect(mSpotifyAppRemote);
    }


    private void connected(){
        mSpotifyAppRemote.getPlayerApi().subscribeToPlayerState()
                .setEventCallback(playerState -> {
                    invokeCurrentTrack(playerState.track);
                    invokeIsPaused(playerState.isPaused);
                });
    }

    private void invokeCurrentTrack(Track track){
        List<String> song = Arrays.asList(track.name, track.artist.name, track.uri, track.imageUri.raw);
        methodChannel.invokeMethod("song", song);
    }

    private void invokeIsPaused(boolean isPaused) {
        methodChannel.invokeMethod("isPaused", isPaused);
    }
}

