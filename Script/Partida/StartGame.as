class AStartGame : AActor
{
    UPROPERTY()
    TArray<TSubclassOf<AMage>> Magitos;

    UPROPERTY()
    TArray<AMage> SelectedMages;

    UPROPERTY()
    TSubclassOf<UUserWidget> WidgetClass;

    
    UUserWidget SelectorWidget; 

    UPROPERTY()
    AGridSystem GridSystem; 

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

        // APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();

        // SelectorWidget = Cast<UUserWidget>(WidgetBlueprint::CreateWidget(WidgetClass, pc));
        // Widget::SetInputMode_UIOnlyEx(pc, SelectorWidget);
        // SelectorWidget.AddToViewport(); 
        // pc.bShowMouseCursor = true;


        for ( int i = 0; i < Magitos.Max(); i++)
        {
            AMage magoSpawn = SpawnActor(Magitos[i]);
            magoSpawn.GridSystem =  GridSystem;
            ACell cell = GridSystem.Cells[i];
            magoSpawn.CurrentCell = cell;

            SelectedMages.Add(magoSpawn);

            magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
        }
        

        // auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
        // if(gs != nullptr)
        //     gs.playerTurn = true;
        // gs.playerMages = SelectedMages;

    }

}