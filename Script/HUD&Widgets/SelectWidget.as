class USelectWidget : UUserWidget
{

	TSubclassOf<AMage> SelectedMage;
	UWidget Fila;
	UWidget Error;

	UPROPERTY()
	TArray<TSubclassOf<AMage>> SelectedMages;

	UPROPERTY()
	TArray<TSubclassOf<AMage>> AllMagesArray;

	UFUNCTION()
	void OpenMenu(UWidget FilaBox, UWidget ErrorText)
	{
		if (FilaBox != nullptr)
		{
			FilaBox.IsEnabled = false;
			Fila = FilaBox;
		}

		if(ErrorText != nullptr)
		{
			ErrorText.SetVisibility(ESlateVisibility::Hidden);
			Error = ErrorText;
		}
	}

	UFUNCTION()
	void InitSlots()
	{
		if (SelectedMages.Max() == 0)
		{
			SelectedMages.Add(nullptr);
			SelectedMages.Add(nullptr);
			SelectedMages.Add(nullptr);
		}
	}

	UFUNCTION()
	void HideImages(TArray<UWidget> ArrayImages){
		if(ArrayImages.Num() == 0) return;

		for(UWidget W : ArrayImages){
			W.SetVisibility(ESlateVisibility::Hidden);
		}
	}

	UFUNCTION()
	void FocusMage(EMageType nameMage)
	{
		SelectedMage = nullptr;
		Fila.IsEnabled = true;
		for (auto M : AllMagesArray)
		{
			if (M.DefaultObject.TypeMage == nameMage)
			{
				SelectedMage = M;
				break;
			}
		}
	}

	UFUNCTION()
	void ChooseMage(UImage image, int slot)
	{
		AMage mage = SelectedMage.GetDefaultObject();
		image.SetVisibility(ESlateVisibility::Visible);
		image.SetBrushFromTexture(mage.IconTexture);
		SelectedMages[slot] = SelectedMage;
	}

	UFUNCTION()
	void ConfirmChoice()
	{
		if (SelectedMages.Num() != 3 || SelectedMages.Contains(nullptr))
		{
			Error.SetVisibility(ESlateVisibility::Visible);
        	return;
		}

		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs != nullptr)
		{
			gs.SelectedMages = SelectedMages;
			gs.SpawnCharacters();
			gs.GameStart = true;
		}

		RemoveFromParent();
		APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
		if (pc != nullptr)
		{
			pc.bShowMouseCursor = true;
			pc.bEnableClickEvents = true;
			pc.bEnableMouseOverEvents = true;

			ACatGameController cat = Cast<ACatGameController>(pc);
			if (cat != nullptr && cat.InputComponent != nullptr)
				cat.PushInputComponent(cat.InputComponent);
		}
	}


}