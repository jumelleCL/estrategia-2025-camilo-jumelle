class ACatGamePawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent) UCameraComponent Camera;

    ACatGamePawn()
    {
        Camera.RelativeRotation = FRotator(-20.0, 0.0, 0.0);
        Camera.RelativeLocation = FVector(-800.0, 0.0, 300.0);
    }
}
