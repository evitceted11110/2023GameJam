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
            if (async.progress < 0.9f)
            {
                progress = async.progress;
            }
            else
            {
                progress = 1.0f;
            }
            slider.value = progress;
            text.text = (slider.value * 100) + "%";
            if (GameSceneManager.Instance.NextScene == GameSceneManager.GAME_SCENE)
            {
                if (progress >= 0.90f)
                {
                    if (!pressToStartObject.activeInHierarchy)
                    {
                        pressToStartObject.SetActive(true);
                    }
                    if (Input.anyKeyDown)
                    {
                        async.allowSceneActivation = true;
                    }
                }
            }
            else
            {
                async.allowSceneActivation = true;
            }
            yield return null;
        }
    }
    // Update is called once per frame
    void Update()
    {

    }
}
