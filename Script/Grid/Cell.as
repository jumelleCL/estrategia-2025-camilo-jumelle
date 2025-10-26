class ACell : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent Mesh;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
     default
    {
        Mesh.SetWorldScale3D( FVector(1.0,1.0,1.0) );
    }
};