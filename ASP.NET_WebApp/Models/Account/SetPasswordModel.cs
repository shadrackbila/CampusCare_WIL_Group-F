using System.ComponentModel.DataAnnotations;

public class SetPasswordModel
{
    [Required] public string TokenHash { get; set; }

    [Required, MinLength(8)]
    [DataType(DataType.Password)]
    public string Password { get; set; }

    [Required, Compare(nameof(Password), ErrorMessage = "Passwords do not match.")]
    [DataType(DataType.Password)]
    public string ConfirmPassword { get; set; }
}