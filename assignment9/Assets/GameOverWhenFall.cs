using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverWhenFall : MonoBehaviour {

    private AudioSource playSceneMusic;

	// Use this for initialization
	void Start () {
        playSceneMusic = DontDestroy.instance.GetComponents<AudioSource>()[0];
	}
	
	// Update is called once per frame
	void Update () {
		if (transform.position.y < -1) {
            // stop play scene's music, but allow it to start again when game restarts
            playSceneMusic.Stop();
            DontDestroy.playMusic = false;

            // reset level for next game
            MazeText.level = 1;

            // when player falls through hole, game over
            SceneManager.LoadScene("GameOver");
        }
	}
}
