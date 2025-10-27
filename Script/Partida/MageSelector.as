class AMageSelector : AActor
{
    UPROPERTY()
    TArray<TSubclassOf<AMage>> Magitos;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        for ( int i = 0; i < Magitos.Max(); i++)
        {
            AMage magoSpawn = SpawnActor(Magitos[i], );
            //encontrar 1 cell vacio
        }
    }

}