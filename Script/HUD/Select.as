class USelectWidget : UUserWidget
{

	TSubclassOf<AMage> SelectedMage;

	UPROPERTY()
	TArray<TSubclassOf<AMage>> SelectedMages;

	UPROPERTY()
	TArray<TSubclassOf<AMage>> AllMagesArray;

	UFUNCTION()
	void OpenMenu(UWidget FilaBox)
	{
		if (FilaBox != nullptr)
		{
			FilaBox.IsEnabled = false;
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
	void FocusMage(UWidget FilaBox, EMageType nameMage)
	{
		SelectedMage = nullptr;
		if (FilaBox == nullptr)
			return;
		FilaBox.IsEnabled = true;
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

		image.SetBrushFromTexture(mage.IconTexture);
		SelectedMages[slot] = SelectedMage;
	}

	UFUNCTION()
	void ConfirmChoice()
	{
		auto gs = Cast<AUCatGameState>(GetWorld().GetGameState());
		if(gs != nullptr)
		{
			gs.SelectedMages = SelectedMages;
			gs.SpawnCharacters();
		}

		APlayerController pc = GetWorld().GameInstance.GetFirstLocalPlayerController();
		if(pc != nullptr)
		{
			pc.bShowMouseCursor = true;
			Widget::SetInputMode_GameOnly(pc);
		}

		RemoveFromParent();
	}


}