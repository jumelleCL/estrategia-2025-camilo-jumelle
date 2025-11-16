class AUCatGameState : AGameStateBase
{
	UPROPERTY()
	TArray<TSubclassOf<AMage>> SelectedMages;

	UPROPERTY()
	TArray<TSubclassOf<AMage>> allMages;

	UPROPERTY()
	AGridSystem GridSystem;

	UPROPERTY()
	TArray<AMage> playerMages;

	UPROPERTY()
	TArray<AMage> enemyMages;

	bool PlayerTurn = true;
	bool GameStart = false;
	bool HardDifficulty;

	UPROPERTY()
	AMage PendingEnemy;

	UPROPERTY()
	AMage PendingTarget;

	UPROPERTY()
	FIntPoint PendingMove;

	UPROPERTY()
	bool PendingIsMove = false;

	void SpawnCharacters()
	{
		int cellIndex = 0;
		for (int i = 0; i < SelectedMages.Num(); i++)
		{
			while (cellIndex % 2 == 0)
				cellIndex++;
			TSubclassOf<AMage> MageClass = SelectedMages[i];
			AMage magoSpawn = Cast<AMage>(SpawnActor(MageClass));
			magoSpawn.GridSystem = GridSystem;
			ACell cell = GridSystem.Cells[cellIndex];
			magoSpawn.CurrentCell = cell;
			magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
			playerMages.Insert(magoSpawn);
			cellIndex++;
		}

		int lastIndex = GridSystem.Cells.Num() - 1;

		if (HardDifficulty)
		{
			int spawned = 0;
			while (lastIndex >= 0 && spawned < 7)
			{
				TSubclassOf<AMage> MageClass = allMages[Math::RandRange(0, allMages.Num() - 1)];
				AMage magoSpawn = Cast<AMage>(SpawnActor(MageClass));
				magoSpawn.GridSystem = GridSystem;
				ACell cell = GridSystem.Cells[lastIndex];
				magoSpawn.CurrentCell = cell;
				magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
				magoSpawn.SetActorRotation(FRotator(0, 90, 0));
				magoSpawn.IsPlayerOwner = false;
				enemyMages.Insert(magoSpawn);
				lastIndex--;
				spawned++;
			}
		}
		else
		{
			int placed = 0;
			while (lastIndex >= 0 && placed < 3)
			{
				if (lastIndex % 2 != 0)
				{
					int r = Math::RandRange(0, allMages.Num() - 1);
					TSubclassOf<AMage> MageClass = allMages[r];
					AMage magoSpawn = Cast<AMage>(SpawnActor(MageClass));
					magoSpawn.GridSystem = GridSystem;
					ACell cell = GridSystem.Cells[lastIndex];
					magoSpawn.CurrentCell = cell;
					magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
					magoSpawn.SetActorRotation(FRotator(0, 90, 0));
					magoSpawn.IsPlayerOwner = false;
					enemyMages.Insert(magoSpawn);
					placed++;
				}
				lastIndex--;
			}
		}
	}

	AMage IsCellOccupied(ACell cell)
	{
		TArray<AMage> tAllMages;
		GetAllActorsOfClass(tAllMages);
		for (AMage m : tAllMages)
		{
			if (m.CurrentCell == cell)
				return m;
		}
		return nullptr;
	}

	UFUNCTION()
	void EnemyTakeTurn()
	{
		if (enemyMages.Num() == 0)
		{
			PlayerTurn = true;
			return;
		}

		// Filtrar enemigos válidos
		TArray<AMage> validEnemies;
		for (AMage e : enemyMages)
		{
			if (e != nullptr && e.CurrentCell != nullptr)
				validEnemies.Add(e);
		}

		if (validEnemies.Num() == 0)
		{
			PlayerTurn = true;
			return;
		}

		int r = Math::RandRange(0, validEnemies.Num() - 1);
		AMage enemy = validEnemies[r];

		PendingEnemy = enemy;
		PendingTarget = nullptr;
		PendingIsMove = false;
		PendingMove = FIntPoint();

		for (ACell c : GridSystem.Cells)
			c.ChangeColor(ECellColor::Normal);

		// Intentar atacar primero
		AMage target = nullptr;
		for (FIntPoint atk : enemy.GetAttacks())
		{
			int targetX = enemy.CurrentCell.GridX - atk.X;
			int targetY = enemy.CurrentCell.GridY - atk.Y;
			for (AMage p : playerMages)
			{
				if (p.CurrentCell.GridX == targetX && p.CurrentCell.GridY == targetY)
				{
					target = p;
					break;
				}
			}
			if (target != nullptr)
				break;
		}

		if (target != nullptr)
		{
			PendingTarget = target;
			PendingIsMove = false;
			for (ACell c : GridSystem.Cells)
			{
				if (c.GridX == target.CurrentCell.GridX && c.GridY == target.CurrentCell.GridY)
					c.ChangeColor(ECellColor::Attack);
			}
		}
		else
		{
			// Siempre intentar moverse
			TArray<FIntPoint> possibleMoves;
			for (FIntPoint move : enemy.GetMovements())
			{
				int newX = enemy.CurrentCell.GridX - move.X;
				int newY = enemy.CurrentCell.GridY - move.Y;
				for (ACell c : GridSystem.Cells)
				{
					if (c.GridX == newX && c.GridY == newY && IsCellOccupied(c) == nullptr)
					{
						possibleMoves.Add(move);
					}
				}
			}

			if (possibleMoves.Num() == 0)
			{
				// Si no hay ataque ni movimiento válido, moverse a la celda más cercana vacía
				for (ACell c : GridSystem.Cells)
				{
					if (IsCellOccupied(c) == nullptr)
					{
						FIntPoint move;
						move.X = enemy.CurrentCell.GridX - c.GridX;
						move.Y = enemy.CurrentCell.GridY - c.GridY;

						possibleMoves.Add(move);
						break;
					}
				}
			}

			int moveIndex = Math::RandRange(0, possibleMoves.Num() - 1);
			FIntPoint move = possibleMoves[moveIndex];
			PendingMove = move;
			PendingIsMove = true;
			int newX = PendingEnemy.CurrentCell.GridX - move.X;
			int newY = PendingEnemy.CurrentCell.GridY - move.Y;
			for (ACell c : GridSystem.Cells)
			{
				if (c.GridX == newX && c.GridY == newY)
					c.ChangeColor(ECellColor::Movement);
			}
		}

		System::SetTimer(this, n"DoEnemyAction", Math::RandRange(1.0f, 2.0f), false);
	}

	UFUNCTION()
	void DoEnemyAction()
	{
		if (PendingEnemy == nullptr)
		{
			PlayerTurn = true;
			return;
		}

		if (PendingIsMove)
		{
			int newX = PendingEnemy.CurrentCell.GridX - PendingMove.X; // invertir para enemigo (Línea modificada)
			int newY = PendingEnemy.CurrentCell.GridY - PendingMove.Y; // invertir para enemigo (Línea modificada)
			for (ACell c : GridSystem.Cells)
			{
				if (c.GridX == newX && c.GridY == newY && IsCellOccupied(c) == nullptr)
				{
					PendingEnemy.CurrentCell = c;
					PendingEnemy.SetActorLocation(FVector(c.GetActorLocation().X, c.GetActorLocation().Y, PendingEnemy.GetActorLocation().Z));
					break;
				}
			}
		}
		else if (PendingTarget != nullptr)
		{
			PendingTarget.Hp -= PendingEnemy.Atk;
			PendingTarget.UpdateLife();
			Print("Enemigo " + PendingEnemy.Name + " golpeó a " + PendingTarget.Name);
			if (PendingTarget.Hp <= 0)
				playerMages.Remove(PendingTarget);
		}

		for (ACell c : GridSystem.Cells)
			c.ChangeColor(ECellColor::Normal);

		PendingEnemy = nullptr;
		PendingTarget = nullptr;
		PendingIsMove = false;
		PendingMove = FIntPoint();

		PlayerTurn = true;
	}
}