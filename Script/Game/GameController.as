class ACatGameController : APlayerController{
    default bEnableClickEvents = true;
    default bEnableMouseOverEvents = true;

    UPROPERTY(DefaultComponent)
    UCatGameInput InputComponent;

    UPROPERTY(BlueprintReadOnly)
    AMage SelectedMage;
}
