class AStartGame : AActor
{
    UPROPERTY()
    TArray<TSubclassOf<AMage>> Magitos;

    UPROPERTY()
    TSubclassOf<UUserWidget> WidgetClass;

    
    UUserWidget SelectorWidget; 

    UPROPERTY()
    AGridSystem GridSystem; 

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

        APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();

        SelectorWidget = Cast<UUserWidget>(WidgetBlueprint::CreateWidget(WidgetClass, pc));
        // Widget::SetInputMode_GameAndUIEx(pc, SelectorWidget);
        // pc.bShowMouseCursor = true;
        SelectorWidget.AddToViewport(); 

        auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
        if(gs != nullptr)
            gs.PlayerTurn = true;
            gs.GridSystem = GridSystem;

    }

   

}