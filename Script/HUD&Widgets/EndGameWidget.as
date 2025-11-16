class UEndGameWidget : UUserWidget
{
    UPROPERTY(Meta = (BindWidget))
    UTextBlock TitleText;

    UPROPERTY(Meta = (BindWidget))
    UTextBlock DescriptionText;

    UFUNCTION()
    void Setup(FText title, FText desc)
    {
        TitleText.SetText(title);
        DescriptionText.SetText(desc);
    }

    UFUNCTION()
    void OnMenu()
    {
        Gameplay::OpenLevel(n"Main");
    }

    // UFUNCTION()
    // void OnExit()
    // {
    //     FGenericPlatformMisc::RequestExit(false);
    // }
}
