class AUCatGameState : AGameStateBase
{
    UPROPERTY()
    TArray<TSubclassOf<AMage>> SelectedMages;

    UPROPERTY()
    TArray<AMage> playerMages;

    UPROPERTY()
    AGridSystem GridSystem;

    bool PlayerTurn = true;

        UFUNCTION()
    void SpawnCharacters()
    {
        int cellIndex = 0;
        for(int i = 0; i < SelectedMages.Num(); i++)
        {
            while(cellIndex % 2 == 0) cellIndex++;
            TSubclassOf<AMage> MageClass = SelectedMages[i];
            AMage magoSpawn = Cast<AMage>(SpawnActor(MageClass));
            magoSpawn.GridSystem = GridSystem;
            ACell cell = GridSystem.Cells[cellIndex];
            magoSpawn.CurrentCell = cell;
            magoSpawn.SetActorLocation(FVector(cell.GetActorLocation().X, cell.GetActorLocation().Y, cell.GetActorLocation().Z + 50));
            cellIndex++;
        }
    }

}
