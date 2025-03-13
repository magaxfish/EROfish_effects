using UnityEngine;

public class GhostTrailEffect : MonoBehaviour
{
    public ParticleSystem ghostTrailParticle; // ��J�ɤl�t��
    public Animator animator; // ���⪺ Animator
    public SpriteRenderer spriteRenderer; // ���⪺ SpriteRenderer

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
        // ���o��e�ʵe���A
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        // ���o�����e��ܪ� Sprite
        Sprite currentSprite = spriteRenderer.sprite;

        if (currentSprite != null)
        {
            // ��s�ɤl�t�Ϊ� Sprite
            textureSheetAnimation.SetSprite(0, currentSprite);
        }
    }
}

