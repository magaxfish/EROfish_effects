using UnityEngine;

public class GhostTrailEffect : MonoBehaviour
{
    public ParticleSystem ghostTrailParticle; // 拖入粒子系統
    public Animator animator; // 角色的 Animator
    public SpriteRenderer spriteRenderer; // 角色的 SpriteRenderer

    private ParticleSystem.TextureSheetAnimationModule textureSheetAnimation;
    private ParticleSystemRenderer particleRenderer;

    void Start()
    {
        textureSheetAnimation = ghostTrailParticle.textureSheetAnimation;
        particleRenderer = ghostTrailParticle.GetComponent<ParticleSystemRenderer>();
    }

    void Update()
    {
        UpdateParticleSprite();
    }

    void UpdateParticleSprite()
    {
        // 取得當前動畫狀態
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        // 取得角色當前顯示的 Sprite
        Sprite currentSprite = spriteRenderer.sprite;

        if (currentSprite != null)
        {
            // 更新粒子系統的 Sprite
            textureSheetAnimation.SetSprite(0, currentSprite);
        }
    }
}

