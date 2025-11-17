class AStartGame : AActor
{
	UPROPERTY()
	TArray<TSubclassOf<AMage>> Magitos;

	UPROPERTY()
	TSubclassOf<UUserWidget> WidgetClass;

	UUserWidget SelectorWidget;

	UPROPERTY()
	AGridSystem GridSystem;

	UPROPERTY()
	TSubclassOf<UEndGameWidget> EndGameWidgetBP;

	UPROPERTY()
	AStaticMeshActor SkyMesh;

	float TimeAccumulator = 0;

	// UFUNCTION(BlueprintOverride)
	// void Tick(float DeltaTime)
	// {
	// 	TimeAccumulator += DeltaTime;
	// 	if (TimeAccumulator < 0.05)
	// 		return;
	// 	TimeAccumulator = 0;

	// 	if (SkyMesh == nullptr)
	// 		return;
	// 	FRotator r = SkyMesh.GetActorRotation();
	// 	r.Yaw += 1.0;
	// 	SkyMesh.SetActorRotation(r);
	// }

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{

		APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();

		SelectorWidget = Cast<UUserWidget>(WidgetBlueprint::CreateWidget(WidgetClass, pc));
		// Widget::SetInputMode_GameAndUIEx(pc, SelectorWidget);
		// pc.bShowMouseCursor = true;
		SelectorWidget.AddToViewport();

		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if (gs != nullptr)
			gs.PlayerTurn = true;
		gs.EndGameWidgetBP = EndGameWidgetBP;
		gs.GridSystem = GridSystem;
		gs.allMages = Magitos;
	}
}