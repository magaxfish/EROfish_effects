using UnityEngine;

public class GhostTrailEffect : MonoBehaviour
{
    public ParticleSystem ghostTrailParticle; // ╈采╰参
    public Animator animator; // à︹ Animator
    public SpriteRenderer spriteRenderer; // à︹ SpriteRenderer

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
        // 眔讽玡笆礶篈
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        // 眔à︹讽玡陪ボ Sprite
        Sprite currentSprite = spriteRenderer.sprite;

        if (currentSprite != null)
        {
            // 穝采╰参 Sprite
            textureSheetAnimation.SetSprite(0, currentSprite);
        }
    }
}

