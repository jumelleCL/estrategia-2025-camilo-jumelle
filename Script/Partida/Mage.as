class AMage : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USkeletalMeshComponent Body;

    UPROPERTY(DefaultComponent, Attach = "Body")
    USphereComponent Collision;

    ACell CurrentCell;
    
    UPROPERTY()
    AGridSystem GridSystem; 


    bool bDragging = false;


    // Creación del mago con sus collisiones
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Collision.SetSphereRadius(50.0);
        Collision.SetGenerateOverlapEvents(true);

        Body.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
        Body.SetCollisionProfileName(FName("BlockAll"));
        Body.SetGenerateOverlapEvents(true);    

        SetActorLocation(FVector(GetActorLocation().X,GetActorLocation().Y, -30));
        SetActorRotation(FRotator(GetActorRotation().Pitch, -90, GetActorRotation().Roll));

        EnableInput(GetWorld().GetGameInstance().GetFirstLocalPlayerController());
    }

    // Input, hace al mago agarrable
    void CheckMouseInput()
    {
        APlayerController pc = GetWorld().GetGameInstance().GetFirstLocalPlayerController();
        if (pc == nullptr) return;

        FHitResult hit;

        if (pc.WasInputKeyJustPressed(EKeys::LeftMouseButton))
        {
            if (pc.GetHitResultUnderCursorByChannel(ETraceTypeQuery::TraceTypeQuery1, false, hit))
            {
                if (hit.GetActor() == this)
                {
                    bDragging = true;
                }
            }
        }

        if (pc.WasInputKeyJustReleased(EKeys::LeftMouseButton) && bDragging)
        {
            bDragging = false;

            if (GridSystem != nullptr && GridSystem.Cells.Num() > 0)
            {
                float closestDist = 999999.0;
                ACell closest = nullptr;
                for (int i = 0; i < GridSystem.Cells.Num(); i++)
                {
                    ACell cell = GridSystem.Cells[i];
                    // Print("Location cell" + cell.GetActorLocation());
                    float dist = (cell.GetActorLocation() - GetActorLocation()).Size();
                    if (dist < closestDist)
                    {
                        closestDist = dist;
                        closest = cell;
                    }
                }

                if (closest != nullptr)
                {
                    SetActorLocation(FVector(closest.GetActorLocation().X, closest.GetActorLocation().Y, GetActorLocation().Z));
                    CurrentCell = closest;
                }
            }
        }
    }

    // Checkando si se agarra o no el bicho
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        CheckMouseInput();

        if (bDragging)
        {
            APlayerController pc = GetWorld().GetGameInstance().GetFirstLocalPlayerController();
            if (pc != nullptr)
            {
                FVector WorldPos, WorldDir;
                if (pc.DeprojectMousePositionToWorld(WorldPos, WorldDir))
                {
                    float t = (GetActorLocation().Z - WorldPos.Z) / WorldDir.Z;
                    FVector NewLoc = WorldPos + WorldDir * t;
                    SetActorLocation(NewLoc);
                }
            }
        }
    }


}
