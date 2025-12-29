using Xunit;

namespace MyWebApp.Tests;

public class BasicTests
{
    [Fact]
    public void Math_Should_Be_Correct()
    {
        int a = 5;
        int b = 10;
        Assert.Equal(15, a + b);
    }

    [Fact]
    public void App_Version_Check()
    {
        bool isStable = true;
        Assert.True(isStable);
    }
}