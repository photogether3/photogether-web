import { Application } from "@hotwired/stimulus";
import { HelloController } from "./hello_controller";
import { FlashController } from "./flash_controller";
import { ModalController } from "./modal_controller";
import { TinymceController } from "./tinymce_controller";
import { NotYetController } from "./not_yet_controller";
import { DynamicScrollGradientController} from "./dynamic_scroll_gradient_controller";

const application = Application.start();

application.register("hello", HelloController);
application.register("flash", FlashController);
application.register("tinymce", TinymceController);
application.register("modal", ModalController);
application.register("not_yet", NotYetController);
application.register("dynamic-scroll-gradient", DynamicScrollGradientController);

// 여러 경로에서 컨트롤러 파일 로드
// const controllerPaths = {
//   ...import.meta.glob("./**/*_controller.js", { eager: true }),
//   ...import.meta.glob("../../views/**/*_controller.js", { eager: true }),
// };

// Object.entries(controllerPaths).forEach(([path, controller]) => {
//   try {
//     // 파일 경로에서 컨트롤러 이름 추출 (예: hello_controller.js -> hello)
//     const match = path.match(/\/([^/]+)_controller\.js$/);
//     if (!match) {
//       console.warn(`Skipping file with invalid naming pattern: ${path}`);
//       return;
//     }

//     const controllerName = match[1].replace(/_/g, "-");

//     // 클래스 이름 생성 (예: hello -> HelloController)
//     const className =
//       controllerName
//         .replace(/-/g, "_")
//         .replace(/(?:^|_)([a-z])/g, (_, letter) => letter.toUpperCase()) +
//       "Controller";

//     // 컨트롤러 클래스 가져오기 (default export 또는 named export)
//     const ControllerClass = controller.default || controller[className];

//     if (ControllerClass) {
//       console.log(`Registering controller: ${controllerName} from ${path}`);
//       application.register(controllerName, ControllerClass);
//     } else {
//       console.warn(
//         `Controller class not found for ${controllerName} (${className}) in ${path}`
//       );
//       console.warn("Available exports:", Object.keys(controller));
//     }
//   } catch (error) {
//     console.error(`Error registering controller for path ${path}:`, error);
//   }
// });
