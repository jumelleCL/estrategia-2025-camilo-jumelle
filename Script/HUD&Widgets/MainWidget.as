class UMainWidget : UUserWidget {

    UPROPERTY(EditAnywhere)
    TSubclassOf<UUserWidget> SelectorWidgetBP;

    UFUNCTION()
    void SetDifficulty(bool isHard){
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
        gs.HardDifficulty = isHard;
    }

    UFUNCTION()
    void StartMenu(UWidget TargetVBox) {
        if (TargetVBox != nullptr)
            TargetVBox.SetVisibility(ESlateVisibility::Hidden);
    }

    UFUNCTION()
    void ToggleMenus(UWidget CloseVBox, UWidget OpenVBox) {
        if (CloseVBox != nullptr)
            CloseVBox.SetVisibility(ESlateVisibility::Hidden);
        if (OpenVBox != nullptr)
            OpenVBox.SetVisibility(ESlateVisibility::Visible);
    }

    UFUNCTION()
    void StartGame(){
        APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
        RemoveFromParent();

        
        UUserWidget SelectorWidget = Cast<UUserWidget>(WidgetBlueprint::CreateWidget(SelectorWidgetBP, pc));
        SelectorWidget.AddToViewport();
    }

}
