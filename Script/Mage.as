    class AMage : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USkeletalMeshComponent Body;

        UPROPERTY(DefaultComponent, Attach = "Body")
        USphereComponent Collision;

        ACell CurrentCell;
        
        AGridSystem GridSystem; 


        bool bDragging = false;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Collision.SetSphereRadius(50.0);
            Collision.SetGenerateOverlapEvents(true);

            Body.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
            Body.SetCollisionProfileName(FName("BlockAll"));
            Body.SetGenerateOverlapEvents(true);    

            EnableInput(GetWorld().GetGameInstance().GetFirstLocalPlayerController());
        }
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

            // Centrar en la celda más cercana al soltar
            if (GridSystem != nullptr && GridSystem.Cells.Num() > 0)
            {
                float closestDist = 999999.0;
                ACell closest = nullptr;
                for (int i = 0; i < GridSystem.Cells.Num(); i++)
                {
                    ACell cell = GridSystem.Cells[i];
                    float dist = (cell.GetActorLocation() - GetActorLocation()).Size();
                    if (dist < closestDist)
                    {
                        closestDist = dist;
                        closest = cell;
                    }
                }

                if (closest != nullptr)
                {
                    SetActorLocation(closest.GetActorLocation());
                    CurrentCell = closest;
                }
            }
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        CheckMouseInput();

        // Arrastrar con el mouse
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
