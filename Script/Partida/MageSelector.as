class AMageSelector : AActor
{
    UPROPERTY()
    TArray<TSubclassOf<AMage>> Magitos;

    UPROPERTY()
    AGridSystem GridSystem; 

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        for ( int i = 0; i < Magitos.Max(); i++)
        {
            AMage magoSpawn = SpawnActor(Magitos[i]);
            magoSpawn.GridSystem =  GridSystem;
            ACell cell = GridSystem.Cells[i];

            magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
        }
    }

}