using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MazeText : MonoBehaviour {

	// for keeping track of number of maze player is currently in
	public static int level = 1;

	public Text mazeText;

	// Use this for initialization
	void Start () {
		mazeText = GetComponent<Text>();
	}
	
	// Update is called once per frame
	void Update () {
		mazeText.text = "Maze #" + level;
	}
}
