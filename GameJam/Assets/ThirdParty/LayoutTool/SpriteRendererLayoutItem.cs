using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;


    [ExecuteInEditMode]
    public class SpriteRendererLayoutItem : ILayoutComponent
    {
        [SerializeField, ReadOnly]
        private Vector2 size;
        [SerializeField]
        private SpriteRenderer sp;

        public override float GetHeight()
        {
            return sp.size.y * transform.localScale.y;
        }

        public override float GetWidth()
        {
            return sp.size.x * transform.localScale.x;
        }

        // Use this for initialization
        void Awake()
        {
            if (sp == null)
                sp = GetComponent<SpriteRenderer>();

            UpdateSize();
        }
        [ContextMenu("UpdateSize")]
        private void UpdateSize()
        {
            size = new Vector2(GetWidth(), GetHeight());
        }
    }

