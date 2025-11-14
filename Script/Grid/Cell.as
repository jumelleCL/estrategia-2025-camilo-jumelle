UENUM()
enum ECellColor
{
    Normal,
    Movement,
    Attack
};
class ACell : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent Mesh;

    UPROPERTY()
    UMaterial NormalMaterial;

    UPROPERTY()
    UMaterial MovementMaterial;

    UPROPERTY()
    UMaterial AttackMaterial;

    UPROPERTY()
    int GridX;

    UPROPERTY()
    int GridY;

    UPROPERTY()
    ECellColor CurrentColor;

    default
    {
        Mesh.SetWorldScale3D(FVector(1.0,1.0,1.0));
        CurrentColor = ECellColor::Normal;
    }

    UFUNCTION()
    void ChangeColor(ECellColor NewColor)
    {
        CurrentColor = NewColor;
        if (NewColor == ECellColor::Normal)
            Mesh.SetMaterial(0, NormalMaterial);
        else if (NewColor == ECellColor::Movement)
            Mesh.SetMaterial(0, MovementMaterial);
        else if (NewColor == ECellColor::Attack)
            Mesh.SetMaterial(0, AttackMaterial);
    }
}
