public class GDO_SetupButton_Ctrl {

   public Boolean setupComplete { get; private set; }

   public GDO_SetupButton_Ctrl() {
      setupComplete = false;
   }

   public void runReplace() {
      GDO_Init.setupOrg();
      Boolean setupComplete = true;
   }

}