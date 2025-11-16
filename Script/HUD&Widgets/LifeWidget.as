class ULifeCatWidget : UUserWidget
{
    UPROPERTY()
    UProgressBar ProgressBar;

    UPROPERTY()
    UImage LastImage;

    
    UPROPERTY()
    UImage FirstImage;

    UFUNCTION()
    void OnConstruct(UProgressBar bar, UImage LastImg, UImage FirstImg)
    {
        ProgressBar = bar;
        LastImage = LastImg;
        FirstImage = FirstImg;

        SetLife(1.0);
    }

    UFUNCTION()
    void SetLife(float percent)
    {
        if(ProgressBar != nullptr)
            ProgressBar.SetPercent(percent);
        if(LastImage != nullptr)
            LastImage.SetVisibility(percent >= 1.0 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
        if(FirstImage != nullptr)
            FirstImage.SetVisibility(percent <= 0.0 ? ESlateVisibility::Visible : ESlateVisibility::Collapsed);
    }
}
