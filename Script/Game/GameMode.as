class ACatGameGameMode : AGameModeBase
{
    ACatGameGameMode()
    {
        DefaultPawnClass = ACatGamePawn::StaticClass();
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        APlayerController pc = GetWorld().GetGameInstance().GetFirstLocalPlayerController();
        if (pc != nullptr)
        {
            pc.bShowMouseCursor = true;
            pc.bEnableClickEvents = true;
            pc.bEnableMouseOverEvents = true;
        }
    }
}
