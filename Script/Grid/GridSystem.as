class AGridSystem : AActor
{
    UPROPERTY()
    TSubclassOf<AActor> cell;

    UPROPERTY()
    int maxActors = 35;

    UPROPERTY()
    int maxRows = 5;

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
            int row = Math::IntegerDivisionTrunc(i, maxRows);
            int col = i % maxRows;

            FVector spawnLocation;
            spawnLocation.X = baseLocation.X + col * spaceBetween;
            spawnLocation.Y = baseLocation.Y + row * spaceBetween;
            spawnLocation.Z = baseLocation.Z;

            AActor spawned = SpawnActor(cell, spawnLocation, FRotator::ZeroRotator);
            ACell c = Cast<ACell>(spawned);
            if (c != nullptr)
                Cells.Add(c);
        }
    }
}
