class ACameraGameMode : AGameModeBase
{
    ACameraGameMode()
    {
        DefaultPawnClass = ACameraPawn::StaticClass();
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        APlayerController pc = GetWorld().GetGameInstance().GetFirstLocalPlayerController();
        pc.bShowMouseCursor = true;
        pc.bEnableClickEvents =true;
        pc.bEnableMouseOverEvents = true;
    }
}
