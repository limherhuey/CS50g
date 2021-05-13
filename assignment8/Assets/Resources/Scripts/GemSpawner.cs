using UnityEngine;
using System.Collections;

public class GemSpawner : MonoBehaviour {

	public GameObject[] prefabs;

	void Start () {

		// infinite gem spawning function, asynchronous
		StartCoroutine(SpawnGems());
	}

	void Update () {

	}

	IEnumerator SpawnGems() {
		while (true) {

			// instantiate gem at a random y position
			Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);

			// pause 3-10 seconds until the next gem spawns
			yield return new WaitForSeconds(Random.Range(3, 10));
		}
	}
}
