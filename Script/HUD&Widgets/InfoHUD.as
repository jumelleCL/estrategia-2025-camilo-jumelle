class AInfoHUD : AHUD{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        mPlayerController = GetOwningPlayerController();

        if(mHud == nullptr)
            {mHud = Cast<UInfoWidget>(WidgetBlueprint::CreateWidget(mHudClass, mPlayerController));}
            
        mHud.AddToViewport();
        // mHud.OpenMenu();
    }

    UFUNCTION(BlueprintEvent)
    void OpenMenu(){
        isMenuClosed = !isMenuClosed;

        mHud.OpenMenu(isMenuClosed);
    }

    UPROPERTY()
    bool isMenuClosed = false;

    UPROPERTY()
    TSubclassOf<UInfoWidget> mHudClass;

    APlayerController mPlayerController;

    UInfoWidget mHud;
}