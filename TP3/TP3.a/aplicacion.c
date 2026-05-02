#include <efi.h>
#include <efilib.h>

EFI_STATUS
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);

    Print(L"Iniciando analisis de seguridad...\r\n");

    unsigned char code[] = { 0xCC };

    if (code[0] == 0xCC) {
        Print(L"Breakpoint estatico alcanzado.\r\n");
    }

    return EFI_SUCCESS;
}
