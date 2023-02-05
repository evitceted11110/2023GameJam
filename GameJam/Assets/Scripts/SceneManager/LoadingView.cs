using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class LoadingView : MonoBehaviour
{
    private float progress;
    [SerializeField]
    private Slider slider;
    [SerializeField]
    private TextMeshProUGUI text;
    [SerializeField]
    private GameObject pressToStartObject;
    private AsyncOperation async;
    private float currentValue;
    [SerializeField]
    [Range(0, 1)]
    private float progressAnimationMultiplier = 0.25f;
    // Start is called before the first frame update

    private void Start()
    {
        pressToStartObject.SetActive(false);
        if (GameSceneManager.Instance.NextScene == GameSceneManager.GAME_SCENE)
        {
            GameResultManager.Instance.ResetManager();
        }
        StartCoroutine(LoadScene());
    }

    IEnumerator LoadScene()
    {
        text.text = "0%";
        async = SceneManager.LoadSceneAsync(GameSceneManager.Instance.NextScene);
        async.allowSceneActivation = false;
        while (!async.isDone)
        {

           
            // Assign current load progress, divide by 0.9f to stretch it to values between 0 and 1.
            progress = async.progress / 0.9f;
            // Calculate progress value to display.
            currentValue = Mathf.MoveTowards(currentValue, progress, progressAnimationMultiplier * Time.deltaTime);
            slider.value = currentValue;
            // When the progress reaches 1, allow the process to finish by setting the scene activation flag.
            slider.value = progress;
            text.text = (slider.value * 100) + "%";

            if (GameSceneManager.Instance.NextScene == GameSceneManager.GAME_SCENE)
            {

            }

            if (Mathf.Approximately(currentValue, 1))
            {
                async.allowSceneActivation = true;
            }
            yield return null;
        }
    }

}
