class ASelectHUD : AHUD{
    UFUNCTION(BlueprintEvent)
    void OpenMenu(){
        PrintError("this should be overriten");
    }

    UPROPERTY()
    bool isMenuOpen = true;
    
}