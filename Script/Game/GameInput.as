class UCatGameInput : UEnhancedInputComponent
{
	UPROPERTY(Category = "Inputs")
	UInputAction leftClick;

	UPROPERTY(Category = "Inputs")
	UInputMappingContext ctx;

	ACatGameController controller;

	bool bDragging = false;
	ACell originalCell;
	FVector originalLocation;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		controller = Cast<ACatGameController>(GetOwner());
		controller.PushInputComponent(this);

		controller.bShowMouseCursor = true;																						

		UEnhancedInputLocalPlayerSubsystem subsys = UEnhancedInputLocalPlayerSubsystem::Get(controller);
		subsys.AddMappingContext(ctx, Priority = 1, Options = FModifyContextOptions());											

		BindAction(leftClick, ETriggerEvent::Started, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftPressed"));
		BindAction(leftClick, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftMove"));
		BindAction(leftClick, ETriggerEvent::Ongoing, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftMove"));
		BindAction(leftClick, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftReleased"));
		BindAction(leftClick, ETriggerEvent::Canceled, FEnhancedInputActionHandlerDynamicSignature(this, n"handledLeftReleased"));
	}

	UFUNCTION()
	private void handledLeftPressed(FInputActionValue ActionValue, float32 ElapsedTime,
							float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (controller == nullptr)
			return;

		FHitResult hit;
		if (controller.GetHitResultUnderCursorByChannel(ETraceTypeQuery::TraceTypeQuery1, false, hit))
		{
			AMage hitMage = Cast<AMage>(hit.GetActor());
			if (hitMage != nullptr)
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
		if (controller == nullptr || controller.SelectedMage == nullptr)
			return;

		AMage mage = controller.SelectedMage;
		ACell closest = mage.GetClosestCell(mage.GetActorLocation());

		if (closest != nullptr && closest.CurrentColor == ECellColor::Movement)
		{
			mage.SetActorLocation(FVector(closest.GetActorLocation().X, closest.GetActorLocation().Y, mage.GetActorLocation().Z));
			mage.CurrentCell = closest;
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
