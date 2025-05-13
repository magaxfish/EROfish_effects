using UnityEngine;

public class FireTrailMover : MonoBehaviour
{
    public Transform[] pathPoints; // ���w���|�I
    public float moveSpeed = 5f;    // ���ʳt�סA�i�վ�
    private int currentPointIndex = 0;

    void Update()
    {
        if (currentPointIndex >= pathPoints.Length) return;

        Transform target = pathPoints[currentPointIndex];
        transform.position = Vector3.MoveTowards(transform.position, target.position, moveSpeed * Time.deltaTime);

        if (Vector3.Distance(transform.position, target.position) < 0.1f)
        {
            currentPointIndex++;
        }
    }
}
