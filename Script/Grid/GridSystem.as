class AGridSystem : AActor
{
    UPROPERTY()
    TSubclassOf<AActor> cell;

    UPROPERTY()
    int maxActors = 35;

    UPROPERTY()
    int maxCols = 7;

    UPROPERTY()
    float spaceBetween = 120.0;
    
    UPROPERTY()
    TArray<ACell> Cells;


    // Spawn del grid
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        FVector baseLocation = GetActorLocation(); 
        for (int i = 0; i < maxActors; i++)
        {
            int col = Math::IntegerDivisionTrunc(i, maxCols);
            int row = i % maxCols;

            FVector spawnLocation;
            spawnLocation.X = baseLocation.X + col * spaceBetween;
            spawnLocation.Y = baseLocation.Y + row * spaceBetween;
            spawnLocation.Z = baseLocation.Z;


            // Spawneamos la celda
            AActor spawned = SpawnActor(cell, spawnLocation, FRotator::ZeroRotator);
            // Añadimos la celda al array para controlarlo
            ACell c = Cast<ACell>(spawned);
            if(c != nullptr)
            {
                c.GridX = col;
                c.GridY = row;
                Cells.Add(c);
            }
        }


    }
}
