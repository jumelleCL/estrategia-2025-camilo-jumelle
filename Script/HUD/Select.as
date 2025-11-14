class USelectWidget : UUserWidget{

    UFUNCTION()
    void ConfirmChoice(){
        
    }

    UFUNCTION(BlueprintEvent)
    void OpenMenu(){
        PrintError("this should be overriten");
    }
    
}