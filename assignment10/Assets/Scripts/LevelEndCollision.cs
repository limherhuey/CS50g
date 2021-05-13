using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelEndCollision : MonoBehaviour {

	void OnControllerColliderHit(ControllerColliderHit hit) {
        // when level end area is reached
		if (hit.gameObject.tag == "endgame") {
			LevelEndText.levelEnded = true;
		}
	}
}
