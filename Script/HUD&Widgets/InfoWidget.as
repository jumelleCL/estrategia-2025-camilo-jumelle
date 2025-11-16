class UInfoWidget : UUserWidget{
    UPROPERTY(Category = "Animations", Transient, Meta = (BindWidgetAnim))
    UWidgetAnimation InOut;

    UFUNCTION()
    void OpenMenu(bool bReverse = false)
    {
        QueuePlayAnimation(InOut, 
        PlayMode = (bReverse ? EUMGSequencePlayMode::Forward : EUMGSequencePlayMode::Reverse));
    }
}