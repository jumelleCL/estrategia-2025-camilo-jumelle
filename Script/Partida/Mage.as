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

	ACell CurrentCell;

	UPROPERTY()
	AGridSystem GridSystem;

	int Hp = 100;
	int Atk = 20;

	UPROPERTY()
	EMageType TypeMage;

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
		Collision.SetSphereRadius(50.0);
		Collision.SetGenerateOverlapEvents(true);

		Body.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Body.SetCollisionProfileName(FName("BlockAll"));
		Body.SetGenerateOverlapEvents(true);

		SetActorLocation(FVector(GetActorLocation().X, GetActorLocation().Y, -90));
		SetActorRotation(FRotator(GetActorRotation().Pitch, -90, GetActorRotation().Roll));
	}

	UFUNCTION()
	TArray<FIntPoint> GetMovements()
	{
		TArray<FIntPoint> r;
		if (TypeMage == EMageType::Mage_Mage)
		{
			FIntPoint p; p.X = 1; p.Y = 0; r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Knigth)
		{
			FIntPoint p;
			p.X = 2; p.Y = 0; r.Add(p);
			p.X = -2; p.Y = 0; r.Add(p);
			p.X = 0; p.Y = 2; r.Add(p);
			p.X = 0; p.Y = -2; r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Priest)
		{
			FIntPoint p;
			for (int i = 1; i < 8; i++)
			{
				p.X = i; p.Y = i; r.Add(p);
				p.X = -i; p.Y = i; r.Add(p);
				p.X = i; p.Y = -i; r.Add(p);
				p.X = -i; p.Y = -i; r.Add(p);
			}
		}
		else if (TypeMage == EMageType::Mage_Shielder)
		{
			FIntPoint p;
			for (int i = 1; i < 8; i++)
			{
				p.X = i; p.Y = 0; r.Add(p);
				p.X = -i; p.Y = 0; r.Add(p);
				p.X = 0; p.Y = i; r.Add(p);
				p.X = 0; p.Y = -i; r.Add(p);
			}
		}
		return r;
	}

	UFUNCTION()
	TArray<FIntPoint> GetAttacks()
	{
		TArray<FIntPoint> r;
		if (TypeMage == EMageType::Mage_Mage)
		{
			FIntPoint p;
			for (int i = 1; i <= 5; i++)
			{
				p.X = i; p.Y = 0; r.Add(p);
				p.X = -i; p.Y = 0; r.Add(p);
			}
		}
		else if (TypeMage == EMageType::Mage_Knigth)
		{
			FIntPoint p;
			p.X = 1; p.Y = 0; r.Add(p);
			p.X = -1; p.Y = 0; r.Add(p);
			p.X = 0; p.Y = 1; r.Add(p);
			p.X = 0; p.Y = -1; r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Priest)
		{
			FIntPoint p;
			p.X = 1; p.Y = 0; r.Add(p);
			p.X = -1; p.Y = 0; r.Add(p);
			p.X = 0; p.Y = 1; r.Add(p);
			p.X = 0; p.Y = -1; r.Add(p);
		}
		else if (TypeMage == EMageType::Mage_Shielder)
		{
			FIntPoint p;
			for (int i = 1; i < 8; i++)
			{
				p.X = i; p.Y = i; r.Add(p);
				p.X = -i; p.Y = i; r.Add(p);
				p.X = i; p.Y = -i; r.Add(p);
				p.X = -i; p.Y = -i; r.Add(p);
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
		if (GridSystem == nullptr) return;
		for (ACell cell : GridSystem.Cells)
			cell.ChangeColor(ECellColor::Normal);
	}
}
