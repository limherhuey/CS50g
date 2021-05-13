using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BackToTitleScreen : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		//submit is equivalent to enter if on keyboard
		if (Input.GetAxis("Submit") == 1) {
			SceneManager.LoadScene("Title");
		}
	}
}
