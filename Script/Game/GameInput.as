class UCatGameInput : UEnhancedInputComponent
{
	UPROPERTY(Category = "Inputs")
	UInputAction leftClick;

	
	UPROPERTY(Category = "Inputs")
	UInputAction rightClick;

	UPROPERTY(Category = "Inputs")
	UInputMappingContext ctx;

	ACatGameController controller;

	bool bDragging = false;
	ACell originalCell;
	FVector originalLocation;
	AInfoHUD hud;

	AMage IsCellOccupied(ACell cell)
	{
		
		TArray<AMage> allMages;
		GetAllActorsOfClass(allMages); 
		for (AMage m : allMages)
		{
			if (m.CurrentCell == cell)
				return m;
		}
		return nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		controller = Cast<ACatGameController>(GetOwner());
		controller.PushInputComponent(this);

		controller.bShowMouseCursor = true;

		UEnhancedInputLocalPlayerSubsystem subsys = UEnhancedInputLocalPlayerSubsystem::Get(controller);
		subsys.AddMappingContext(ctx, Priority = 1, Options = FModifyContextOptions());
		
		hud = Cast<AInfoHUD>(controller.GetHUD());

		// HUD
		BindAction(rightClick, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"handleRightPressed"));

		// Movement / Atack char 
		BindAction(leftClick, ETriggerEvent::Started, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftPressed"));
		BindAction(leftClick, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftMove"));
		BindAction(leftClick, ETriggerEvent::Ongoing, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftMove"));
		BindAction(leftClick, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftReleased"));
	}

	UFUNCTION()
	private void handleRightPressed(FInputActionValue ActionValue, float32 ElapsedTime,
							float32 TriggeredTime, const UInputAction SourceAction)
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs.GameStart)
		{
			hud.OpenMenu();
		}
	}

	bool IsPlayerMage(AMage m)
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		for (AMage p : gs.playerMages)
		{
			if (p == m)
				return true;
		}
		return false;
	}


	UFUNCTION()
	private void handledLeftPressed(FInputActionValue ActionValue, float32 ElapsedTime,
							float32 TriggeredTime, const UInputAction SourceAction)
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs.PlayerTurn == false) return;
		if (controller == nullptr)
			return;

		FHitResult hit;
		if (controller.GetHitResultUnderCursorByChannel(ETraceTypeQuery::TraceTypeQuery1, false, hit))
		{
			AMage hitMage = Cast<AMage>(hit.GetActor());
			if (hitMage != nullptr && IsPlayerMage(hitMage))
			{
				controller.SelectedMage = hitMage;
				originalCell = hitMage.CurrentCell;
				originalLocation = hitMage.GetActorLocation();
				bDragging = true;
				hitMage.HighlightMovement();
			}

		}
	}

	UFUNCTION()
	private void handledLeftMove(FInputActionValue ActionValue, float32 ElapsedTime,
						 float32 TriggeredTime, const UInputAction SourceAction)
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs.PlayerTurn == false) return;
		if (!bDragging || controller == nullptr || controller.SelectedMage == nullptr)
			return;

		FVector WorldLoc, WorldDir;
		if (!controller.DeprojectMousePositionToWorld(WorldLoc, WorldDir))
			return;

		float TargetZ = controller.SelectedMage.GetActorLocation().Z;
		float t = (TargetZ - WorldLoc.Z) / WorldDir.Z;
		FVector NewLoc = WorldLoc + WorldDir * t;
		controller.SelectedMage.SetActorLocation(NewLoc);
	}

	UFUNCTION()
	private void handledLeftReleased(FInputActionValue ActionValue, float32 ElapsedTime,
							 float32 TriggeredTime, const UInputAction SourceAction)
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs.PlayerTurn == false) return;
		if (controller == nullptr || controller.SelectedMage == nullptr)
			return;

		AMage mage = controller.SelectedMage;
		ACell closest = mage.GetClosestCell(mage.GetActorLocation());

		AMage cellOcup = IsCellOccupied(closest);
		if (closest != nullptr && closest.CurrentColor == ECellColor::Movement && cellOcup == nullptr)
		{
			mage.SetActorLocation(FVector(closest.GetActorLocation().X, closest.GetActorLocation().Y, mage.GetActorLocation().Z));
			mage.CurrentCell = closest;

			gs.PlayerTurn = false;
			gs.EnemyTakeTurn();
		}
		else if(closest != nullptr && closest.CurrentColor == ECellColor::Attack && cellOcup != nullptr)
		{
			cellOcup.Hp -= mage.Atk;
			cellOcup.UpdateLife();
			mage.SetActorLocation(FVector(originalCell.GetActorLocation().X, originalCell.GetActorLocation().Y, mage.GetActorLocation().Z));
			mage.CurrentCell = originalCell;
			gs.PlayerTurn = false;
			gs.EnemyTakeTurn();
		}
		else
		{
			if (originalCell != nullptr)
			{
				mage.SetActorLocation(FVector(originalCell.GetActorLocation().X, originalCell.GetActorLocation().Y, mage.GetActorLocation().Z));
				mage.CurrentCell = originalCell;
			}
			else
			{
				mage.SetActorLocation(originalLocation);
			}
		}

		mage.ResetHighlight();
		controller.SelectedMage = nullptr;
		bDragging = false;
	}
}
