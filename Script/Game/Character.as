class ACameraPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    UCameraComponent camera;
    
    ACameraPawn()
    {
        camera.RelativeRotation = FRotator(-20.0, 0.0, 0.0);
        camera.RelativeLocation = FVector(-800.0, 0.0, 300.0);
    }
}
