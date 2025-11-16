class AMage : AActor
{

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	USkeletalMeshComponent Body;
	default Body.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
	default Body.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
	default Body.SetGenerateOverlapEvents(true);

	UPROPERTY(DefaultComponent, Attach = "Body")
	USphereComponent Collision;

	UPROPERTY(DefaultComponent)
	UWidgetComponent LifeWidget;

	UPROPERTY()
	TSubclassOf<UUserWidget> LifeWidgetBP;

	UPROPERTY()
	bool IsPlayerOwner = true;

	ACell CurrentCell;

	UPROPERTY()
	AGridSystem GridSystem;

	int Hp = 100;
	int Atk = 20;

	UPROPERTY()
	UTexture2D IconTexture;

	UPROPERTY()
	EMageType TypeMage;
	
	UPROPERTY()
	TSubclassOf<UEndGameWidget> EndGameWidgetBP;


	ACell GetClosestCell(FVector Pos)
	{
		if (GridSystem == nullptr || GridSystem.Cells.Num() == 0)
			return nullptr;

		float closestDist = 999999.0;
		ACell closest = nullptr;

		for (int i = 0; i < GridSystem.Cells.Num(); i++)
		{
			ACell cell = GridSystem.Cells[i];
			float dist = (cell.GetActorLocation() - Pos).Size();
			if (dist < closestDist)
			{
				closestDist = dist;
				closest = cell;
			}
		}

		return closest;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (LifeWidgetBP != nullptr)
		{
			APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
			UUserWidget inst = Cast<UUserWidget>(WidgetBlueprint::CreateWidget(LifeWidgetBP, pc));
			LifeWidget.SetWidget(inst);
			LifeWidget.SetDrawSize(FVector2D(100, 50));

			LifeWidget.SetWidgetSpace(EWidgetSpace::Screen);
			LifeWidget.SetPivot(FVector2D(0.5, 0));
			LifeWidget.SetRelativeLocation(FVector(0, 0, 90));
		}

		Collision.SetSphereRadius(50.0);
		Collision.SetGenerateOverlapEvents(true);
		if (IsPlayerOwner)
		{
			Body.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
			Body.SetCollisionProfileName(FName("BlockAll"));
			Body.SetGenerateOverlapEvents(true);
		}
		else
		{
			Body.SetCollisionEnabled(ECollisionEnabled::NoCollision);
			Collision.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		}

		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, -90));
		SetActorRotation(FRotator(GetActorRotation().Pitch, -90, GetActorRotation().Roll));
	}

	UFUNCTION()
	void UpdateLife()
	{
		auto w = Cast<ULifeCatWidget>(LifeWidget.GetWidget());
		if (w != nullptr)
		{
			w.SetLife(float(Hp) / 100.0);
			if (Hp < 70)
				w.ProgressBar.SetFillColorAndOpacity(FLinearColor(1, .5, 0));
			if (Hp < 50)
				w.ProgressBar.SetFillColorAndOpacity(FLinearColor(1, 0, 0));
		}

		if (Hp <= 0)
		{
			DestroyActor();
			TArray<AMage> allMages;
			GetAllActorsOfClass(allMages);

			bool playerAlive = false;
			bool enemyAlive = false;

			for (AMage m : allMages)
			{
				if (m.IsPlayerOwner)
					playerAlive = true;
				else
					enemyAlive = true;
			}

			if (!playerAlive)
			{
				APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
    			UEndGameWidget w1 = Cast<UEndGameWidget>(WidgetBlueprint::CreateWidget(EndGameWidgetBP, pc));
				w1.Setup(FText::FromString("Derrota"), FText::FromString("Perdiste la partida"));
				w1.AddToViewport();
			}

			if (!enemyAlive)
			{
				APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
    			UEndGameWidget w2 = Cast<UEndGameWidget>(WidgetBlueprint::CreateWidget(EndGameWidgetBP, pc));
				w2.Setup(FText::FromString("Victoria"), FText::FromString("Ganaste la partida"));
				w2.AddToViewport();
			}
		}
	}

	UFUNCTION()
	TArray<FIntPoint> GetMovements()
	{
		TArray<FIntPoint> r;
		FIntPoint p;

		if (TypeMage == EMageType::Mage_Mage)
		{
			for (int dx = -1; dx <= 1; dx++)
			{
				for (int dy = -1; dy <= 1; dy++)
				{
					if (dx == 0 && dy == 0)
						continue;
					p.X = dx;
					p.Y = dy;
					r.Add(p);
				}
			}
		}
		else if (TypeMage == EMageType::Mage_Priest)
		{
			for (int dx = 1; dx <= 2; dx++)
			{
				for (int dy = -dx; dy <= dx; dy++)
				{
					p.X = dx;
					p.Y = dy;
					r.Add(p);
				}
			}
			p.X = 1;
			p.Y = 0;
			r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Shielder)
		{
			p.X = 1;
			p.Y = 0;
			r.Add(p);
			p.X = 1;
			p.Y = 1;
			r.Add(p);
			p.X = 1;
			p.Y = -1;
			r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Knigth)
		{
			for (int i = 1; i <= 8; i++)
			{
				p.X = i;
				p.Y = 0;
				r.Add(p);
				p.X = -i;
				p.Y = 0;
				r.Add(p);
				p.X = 0;
				p.Y = i;
				r.Add(p);
				p.X = 0;
				p.Y = -i;
				r.Add(p);
			}
		}
		return r;
	}

	UFUNCTION()
	TArray<FIntPoint> GetAttacks()
	{
		TArray<FIntPoint> r;
		FIntPoint p;
		const int MaxRange = 8;
		const int SideLimit = 6;

		if (TypeMage == EMageType::Mage_Mage)
		{
			for (int dx = -2; dx <= 2; dx++)
			{
				for (int dy = -2; dy <= 2; dy++)
				{
					if (dx == 0 && dy == 0)
						continue;
					if (Math::Max(Math::Abs(dx), Math::Abs(dy)) == 2)
					{
						p.X = dx;
						p.Y = dy;
						r.Add(p);
					}
				}
			}
		}
		else if (TypeMage == EMageType::Mage_Priest)
		{
			for (int i = -1; i >= -MaxRange; i--)
			{
				p.X = i;
				p.Y = 0;
				r.Add(p);
			}
		}
		else if (TypeMage == EMageType::Mage_Shielder)
		{
			for (int i = -1; i >= -MaxRange; i--)
			{
				for (int j = -SideLimit; j <= SideLimit; j++)
				{
					p.X = i;
					p.Y = j;
					r.Add(p);
				}
			}
		}
		else if (TypeMage == EMageType::Mage_Knigth)
		{
			for (int sx = -1; sx <= 1; sx += 2)
			{
				for (int sy = -1; sy <= 1; sy += 2)
				{
					for (int k = 1; k <= MaxRange; k++)
					{
						p.X = sx * k;
						p.Y = sy * k;
						r.Add(p);
					}
				}
			}
		}
		return r;
	}

	UFUNCTION()
	void HighlightMovement()
	{
		if (GridSystem == nullptr || CurrentCell == nullptr)
			return;

		for (ACell cell : GridSystem.Cells)
			cell.ChangeColor(ECellColor::Normal);

		TArray<FIntPoint> moves = GetMovements();
		for (FIntPoint move : moves)
		{
			int targetX = CurrentCell.GridX + move.X;
			int targetY = CurrentCell.GridY + move.Y;

			for (ACell cell : GridSystem.Cells)
			{
				if (cell.GridX == targetX && cell.GridY == targetY)
					cell.ChangeColor(ECellColor::Movement);
			}
		}

		TArray<FIntPoint> attacks = GetAttacks();
		for (FIntPoint atk : attacks)
		{
			int targetX = CurrentCell.GridX + atk.X;
			int targetY = CurrentCell.GridY + atk.Y;

			for (ACell cell : GridSystem.Cells)
			{
				if (cell.GridX == targetX && cell.GridY == targetY)
					cell.ChangeColor(ECellColor::Attack);
			}
		}
	}

	UFUNCTION()
	void ResetHighlight()
	{
		if (GridSystem == nullptr)
			return;
		for (ACell cell : GridSystem.Cells)
			cell.ChangeColor(ECellColor::Normal);
	}
}
