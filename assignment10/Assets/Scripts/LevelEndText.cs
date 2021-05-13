using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelEndText : MonoBehaviour
{

    public static bool levelEnded = false;

    private Text text;

    // Use this for initialization
    void Start()
    {
        // start with transparent text
        text = GetComponent<Text>();
        text.color = new Color(0, 0, 0, 0);
    }

    // Update is called once per frame
    void Update()
    {
        if (levelEnded) {
            // text is now visible as solid black text
            text.color = new Color(0, 0, 0, 1);
            text.text = "You Won!";
        }
    }
}
